
    % projector resolution
    res_x = 912;
    res_y = 1140;

    A = 135;  % background illumination
    B = 120;  % modulation of the sinusoidal fringe
    freqsH = [1, 8, 48];    % fringe frequency
    freqsV = [1, 8, 48];    % fringe frequency
    steps = [3, 3, 3];     % N-step
    out_dir = 'data\FringePatterns_calib';

    if ~exist(out_dir, 'dir')
        mkdir(out_dir);
    end

    img_index = 0; 

    for dirType = ["H", "V"] 
        for i = 1:length(freqsH)
            fH = freqsH(i);
            fV = freqsV(i);
            N = steps(i);
            for j = 0:N-1
                phase = 2 * pi * j / N;

                % generate
                switch dirType
                    case "H" 
                        y = (0:res_y-1)';
                        pattern = A + B * cos(2 * pi * fH * y / res_y + phase);
                        image = repmat(pattern, 1, res_x);
                    case "V"
                        x = (0:res_x-1);
                        pattern = A + B * cos(2 * pi * fV * x / res_x + phase);
                        image = repmat(pattern, res_y, 1);
                end

                % save
                filename = sprintf('FringePattern_%d.bmp', img_index+1);
                filepath = fullfile(out_dir, filename);
                imwrite(uint8(image), filepath);
                img_index = img_index + 1;
            end
        end
    end
