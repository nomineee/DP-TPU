clear all; clc; close all;
%% DLP4500 sensor size. Refer to the DLP4500 datasheet for details.
sensor_prj_width = 10.8;
sensor_prj_height = 6.8;
prj_width = 912;
prj_height = 1140;
load('data\calib\PrjCalibResult_real.mat');
%%Spot size (field-of-view angle)
seta = rad2deg(2*atan(prj_width/(2*KK(1,1))));
%%Projector principal point offset
up0 = KK(1,3);
vp0 = KK(2,3);
%%Projector RT matrices
Rp = Rc_1;
Tp = Tc_1;
%%Projector skew factor
sf = KK(1,2);
%%scaling factor
zoom = sensor_prj_height/sensor_prj_width;
%%Projector skew factor correction
skew_factor_p = sf./KK(1,1);
%%Projector pose
Rpx_angle =  rad2deg(atan(Rp(2,3)/Rp(3,3)));
Rpy_angle =  rad2deg(atan(-Rp(1,3)/sqrt(Rp(2,3)^2+Rp(3,3)^2)));
Rpz_angle =  rad2deg(atan(Rp(1,2)/Rp(1,1)));
Location_p = -Rp'*Tp;
%% Pixel size. Refer to the aca640-750um datasheet for details.
sensor_cam = 0.0048;
cam_width = 640;
cam_height = 480;
load('data\calib\CamCalibResult_real.mat');
%%Camera RT matrices
Rc = Rc_1;
Tc = Tc_1;
%%Camera equivalent focal length
fc = sqrt(KK(1,1)*KK(2,2)*sensor_cam*sensor_cam);
%%Camera principal point offset
uc0 = KK(1,3);
vc0 = KK(2,3);
sensor_cam_width = cam_width*sensor_cam;
%%Camera skew factor
sf = KK(1,2);
skew_factor_c = sf./KK(1,1);
%%Camera pose
Rcx_angle =  rad2deg(atan(Rc(2,3)/Rc(3,3)));
Rcy_angle =  rad2deg(atan(-Rc(1,3)/sqrt(Rc(2,3)^2+Rc(3,3)^2)));
Rcz_angle =  rad2deg(atan(Rc(1,2)/Rc(1,1)));
Location_c = -Rc'*Tc;

fprintf('***************projector***************\n');
fprintf('Projector skew factor correction: [%.8f] \n', skew_factor_p);
fprintf('Projector principal point offset correction: [%.8f,%.8f] \n', up0,vp0);
fprintf('Projector spot size: [%.8f]\n',seta);
fprintf('Projector scaling factor: [%.8f] \n', zoom);
fprintf('Projector angles: [%.8f°,%.8f°,%.8f°] \n', Rpx_angle,Rpy_angle,Rpz_angle);
fprintf('Projector position: [%.8f,%.8f,%.8f]mm\n', Location_p);
fprintf('*****************camera****************\n');
fprintf('Camera skew factor correction [%.8f] \n', skew_factor_c);
fprintf('Camera principal point offset correction  [%.8f,%.8f] \n', uc0,vc0);
fprintf('Camera equivalent focal length  [%.8f] \n', fc);
fprintf('Camera angles [%.8f°,%.8f°,%.8f°]\n', Rcx_angle,Rcy_angle,Rcz_angle );
fprintf('Camera position [%.8f,%.8f,%.8f]mm\n', Location_c);

fprintf('***************************************\n');
fprintf('Copy the following code to "apply_calib_to_blender"\n');
fprintf('camera.location[0] = mm(%.4f) \n', Location_c(1));
fprintf('camera.location[1] = mm(%.4f) \n', Location_c(2));
fprintf('camera.location[2] = mm(%.4f) \n', Location_c(3));
fprintf('camera.rotation_euler[0] = math.radians(%.4f) \n', Rcx_angle);
fprintf('camera.rotation_euler[1] = math.radians(%.4f) \n', Rcy_angle);
fprintf('camera.rotation_euler[2] = math.radians(%.4f) \n', Rcz_angle);
fprintf('camera.data.lens = %.2f \n', fc);
fprintf('projector.location[0] = mm(%.4f) \n', Location_p(1));
fprintf('projector.location[1] = mm(%.4f) \n', Location_p(2));
fprintf('projector.location[2] = mm(%.4f) \n', Location_p(3));
fprintf('projector.rotation_euler[0] = math.radians(%.4f) \n', Rpx_angle);
fprintf('projector.rotation_euler[1] = math.radians(%.4f) \n', Rpy_angle);
fprintf('projector.rotation_euler[2] = math.radians(%.4f) \n', Rpz_angle);
fprintf('projector.data.spot_size = %.2f \n', deg2rad(seta));
fprintf('projector.scale[1] = %.4f \n', zoom);