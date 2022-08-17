% Эта функция предназначена для считывания данных из tlk-файла.

function [tpg, tlk_header] = ReadTLKFile(filename)

%  Структура файла TLK
%  |================|  - 0
%  | Заголовок      |
%  |   (TLK_HEADER) |
%  |================|
%         ...
%  |================| - 210
%  |    Данные      |
%  |      ...       |
%  |================|

%  Каждый пиксел хранится как целое число,
%  в 10 раз больше реального,
%  т.о. точность представления - 0.1.

[filepath,name,ext] = fileparts(filename);
if strlength(filepath) + strlength(name) + strlength(ext) == 0
    error('ReadTLKFile:emptyFilename',...
      'Enter a file name, please');
end
if strlength(filepath) >= 247 || (strlength(filepath) + strlength(name)) >= 255
    error('ReadTLKFile:longFilename',...
      'File name too long. Enter a file name with a length 255 symbols, please');
end
if ~strcmp(ext, '.tlk')
    error('ReadTLKFile:invalidFileExtention',...
      'Invalid file extention');
end
if ~exist(filename, 'file')
    error('ReadTLKFile:fileDoesNotExist',...
      'File does not exist');
end


file_id = fopen(filename, 'r');
if file_id == -1
  error('ReadTLKFile:fileDoesNotExist',...
    'File does not exist');
end

tlk_header.filename = filename;
tlk_header.szManifest = fread(file_id, [1,18], '*char');
tlk_header.nDevXLen = fread(file_id, 1, 'uint16');
tlk_header.nDevYLen = fread(file_id, 1, 'uint16');
tlk_header.nDevXSize = fread(file_id, 1, 'uint16');
tlk_header.nDevYSize = fread(file_id, 1, 'uint16');
tlk_header.xPixelSize = tlk_header.nDevXSize * 10 / tlk_header.nDevXLen;
tlk_header.yPixelSize = tlk_header.nDevYSize * 10 / tlk_header.nDevYLen;
tlk_header.ptr = fread(file_id, 1, 'int32');
tlk_header.xscale.nMul = fread(file_id, 1, 'uint16');
tlk_header.xscale.nDiv = fread(file_id, 1, 'uint16');
tlk_header.yscale.nMul = fread(file_id, 1, 'uint16');
tlk_header.yscale.nDiv = fread(file_id, 1, 'uint16');
tlk_header.xStep = tlk_header.xscale.nMul / tlk_header.xscale.nDiv;
tlk_header.yStep = tlk_header.yscale.nMul / tlk_header.yscale.nDiv;
tlk_header.nXStart = fread(file_id, 1, 'int16');
tlk_header.nYStart = fread(file_id, 1, 'int16');
tlk_header.nXSize = fread(file_id, 1, 'int16');
tlk_header.nYSize = fread(file_id, 1, 'int16');
tlk_header.szName = fread(file_id, [1,36], '*char');
tlk_header.szDate = fread(file_id, [1,16], '*char');
tlk_header.comment.szFirstComment = fread(file_id, [1,33], '*char');
tlk_header.comment.szSecondComment = fread(file_id, [1,33], '*char');
tlk_header.comment.szThirdComment = fread(file_id, [1,33], '*char');
tlk_header.trendoff = fread(file_id, 1, 'int16');

fseek(file_id, 210, 'bof');

tpg = fread(file_id, [tlk_header.nXSize,tlk_header.nYSize], 'uint16') / 10;

fclose(file_id);

end