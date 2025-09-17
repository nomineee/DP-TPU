%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3D reconstruction with a calibrated triangulation stereo model
% Related Reference:
%   "Calibration of fringe projection profilometry: A comparative review"
%   Shijie Feng, Chao Zuo, Liang Zhang, Tianyang Tao, Yan Hu, Wei Yin,
%   Jiaming Qian, and Qian Chen
% last modified on: (updated by assistant)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Clean workspace
clc; clear; close all;

%% Step 1: I/O and global parameters
width     = 640;   % camera width  (px)
height    = 480;   % camera height (px)
prj_width = 912;   % projector width (px)
freq      = 96;    % fringe frequency used for phase-to-projector mapping

% Paths (edit if your files are elsewhere)
cam_real_file = 'data\calib\CamCalibResult_real.mat';
cam_sim_file  = 'data\calib\CamCalibResult_sim.mat';
prj_real_file = 'data\calib\PrjCalibResult_real.mat';
prj_sim_file  = 'data\calib\PrjCalibResult_sim.mat';

phase_real_file = 'data\standardball\standardball_phase_real.mat'; % contains variable 'phase3'
phase_sim_file  = 'data\standardball\standardball_phase_sim.mat';  % contains variable 'phase'

%% Step 2: Load calibration (camera/projector) and compose projection matrices
[Pc_real, Pp_real] = load_calib_pair(cam_real_file, prj_real_file);
[Pc_sim,  Pp_sim ] = load_calib_pair(cam_sim_file,  prj_sim_file );

%% Step 3: Load phases (real/sim) and sanitize
up_real = load_phase_any(phase_real_file); % returns double, NaNs where invalid
up_sim  = load_phase_any(phase_sim_file );

%% Step 4: Do 4 reconstructions
% (Calib, Phase) ¡Ê {Real, Sim} ¡Á {Real, Sim}
[R1, rms1] = reconstruct_xyz(Pc_real, Pp_real, up_real, width, height, prj_width, freq); % RR
[R2, rms2] = reconstruct_xyz(Pc_real, Pp_real, up_sim,  width, height, prj_width, freq); % RS
[R3, rms3] = reconstruct_xyz(Pc_sim,  Pp_sim,  up_real, width, height, prj_width, freq); % SR
[R4, rms4] = reconstruct_xyz(Pc_sim,  Pp_sim,  up_sim,  width, height, prj_width, freq); % SS

fprintf('RMS (Calib=Real, Phase=Real): %.3f um\n', rms1*1e3);
fprintf('RMS (Calib=Real, Phase=Sim ): %.3f um\n', rms2*1e3);
fprintf('RMS (Calib=Sim , Phase=Real): %.3f um\n', rms3*1e3);
fprintf('RMS (Calib=Sim , Phase=Sim ): %.3f um\n', rms4*1e3);

%% Step 5: Visualize as 2x2 subplots with RMS under each
figure('Color','w');
tiledlayout(2,2,'Padding','compact','TileSpacing','compact');

% 1: Real calib + Real phase
ax = nexttile; show_cloud(R1.x, R1.y, R1.z);
title('Calib: Real | Phase: Real','FontWeight','bold');
put_rms(ax, rms1);

% 2: Real calib + Sim phase
ax = nexttile; show_cloud(R2.x, R2.y, R2.z);
title('Calib: Real | Phase: Sim','FontWeight','bold');
put_rms(ax, rms2);

% 3: Sim calib + Real phase
ax = nexttile; show_cloud(R3.x, R3.y, R3.z);
title('Calib: Sim | Phase: Real','FontWeight','bold');
put_rms(ax, rms3);

% 4: Sim calib + Sim phase
ax = nexttile; show_cloud(R4.x, R4.y, R4.z);
title('Calib: Sim | Phase: Sim','FontWeight','bold');
put_rms(ax, rms4);

% ---- helper: write RMS under an axes (works even when axis is off) ----
function put_rms(ax, rms_val)
    txt = sprintf('RMS: %.3f \\mum', rms_val*1e3); 
    text(ax, 0.5, -0.04, txt, ...
        'Units','normalized', ...
        'HorizontalAlignment','center', ...
        'VerticalAlignment','top', ...
        'FontSize',10, 'FontWeight','bold', ...
        'Color','w'); 
end

%% ---------------------------- Helper funcs ---------------------------------

function [Pc, Pp] = load_calib_pair(camFile, prjFile)
% Load camera/projector calibration and build 3x4 projection matrices.
% Expected variables in each file: KK, Rc_1, Tc_1
    S = load(camFile);
    assert(isfield(S,'KK') && isfield(S,'Rc_1') && isfield(S,'Tc_1'), ...
        'Missing KK/Rc_1/Tc_1 in %s', camFile);
    Kc = S.KK; Rc = S.Rc_1; Tc = S.Tc_1;
    Pc = Kc * [Rc, Tc];

    S = load(prjFile);
    assert(isfield(S,'KK') && isfield(S,'Rc_1') && isfield(S,'Tc_1'), ...
        'Missing KK/Rc_1/Tc_1 in %s', prjFile);
    Kp = S.KK; Rp = S.Rc_1; Tp = S.Tc_1;
    Pp = Kp * [Rp, Tp];
end

function up = load_phase_any(file)
    S = load(file);
    if isfield(S,'phase3')
        up = double(S.phase3);
    elseif isfield(S,'phase')
        up = double(S.phase);
    else
        error('No phase variable found in %s (expected "phase3" or "phase").', file);
    end
    Mask = abs(up - 0) < 10;
    up(Mask) = NaN;
end

function [R, rms_err] = reconstruct_xyz(Pc, Pp, up_phase, width, height, prj_width, freq)
    % Projector x coordinate from phase
    x_p = up_phase/(2*pi*freq) * prj_width;

    x_rec = nan(height, width);
    y_rec = nan(height, width);
    z_rec = nan(height, width);

    for y = 1:height
        for x = 1:width
            if ~isnan(up_phase(y, x))
                A = [Pc(1,1)-Pc(3,1)*(x-1), Pc(1,2)-Pc(3,2)*(x-1), Pc(1,3)-Pc(3,3)*(x-1);
                     Pc(2,1)-Pc(3,1)*(y-1), Pc(2,2)-Pc(3,2)*(y-1), Pc(2,3)-Pc(3,3)*(y-1);
                     Pp(1,1)-Pp(3,1)*(x_p(y,x)-1), Pp(1,2)-Pp(3,2)*(x_p(y,x)-1), Pp(1,3)-Pp(3,3)*(x_p(y,x)-1)];
                b = [Pc(3,4)*(x-1) - Pc(1,4);
                     Pc(3,4)*(y-1) - Pc(2,4);
                     Pp(3,4)*(x_p(y,x)-1) - Pp(1,4)];
                X = A\b;
                x_rec(y, x) = X(1);
                y_rec(y, x) = X(2);
                z_rec(y, x) = X(3);
            end
        end
    end

    Xv = x_rec(:); Yv = y_rec(:); Zv = z_rec(:);
    valid = ~isnan(Xv) & ~isnan(Yv) & ~isnan(Zv);
    Xv = Xv(valid); Yv = Yv(valid); Zv = Zv(valid);

    xyz = [Xv, Yv, Zv];
    A = [2*xyz, ones(size(xyz,1),1)];
    b = sum(xyz.^2, 2);
    params = A\b;
    x0 = params(1); y0 = params(2); z0 = params(3);
    R_fit = sqrt(params(4) + x0^2 + y0^2 + z0^2);

    dist2center = sqrt((Xv - x0).^2 + (Yv - y0).^2 + (Zv - z0).^2);
    errors = dist2center - R_fit;
    rms_err = sqrt(mean(errors.^2));

    R.x = x_rec; R.y = y_rec; R.z = z_rec;
end

function show_cloud(X, Y, Z)
% Display point cloud in current axes; no toolboxes required.
    ax = gca;
    % Flatten and drop NaNs
    Xv = X(:); Yv = Y(:); Zv = Z(:);
    valid = ~isnan(Xv) & ~isnan(Yv) & ~isnan(Zv);
    Xv = Xv(valid); Yv = Yv(valid); Zv = Zv(valid);

    if exist('pcshow','file') == 2
        % If Computer Vision Toolbox is available
        pcshow([Xv Yv Zv], 'MarkerSize', 20);
    else
        scatter3(Xv, Yv, Zv, 2, Zv, '.'); % fallback
    end
    view(ax, 0, 90);         % top view (change if needed)
    axis(ax, 'equal'); axis(ax, 'tight');
    axis(ax, 'off');
end
