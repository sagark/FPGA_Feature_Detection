function img_to_coe(img_filename)

img = imread(img_filename);
n_row = size(img,1);
n_col = size(img,2);

out_filename = strcat(img_filename(1:end-3),'coe')

out_file = fopen(out_filename,'w');

% sprintf wraps all strings to parse escape characters
fwrite(out_file, sprintf('memory_initialization_radix=16;\n'));
fwrite(out_file, sprintf('memory_initialization_vector=\n'));

for i = 1:n_row
  for j = 1:n_col
    fwrite(out_file,sprintf('%02x',img(i,j,1)));
    if i == n_row && j == n_col
      fwrite(out_file,sprintf(';\n'));
    else
      fwrite(out_file,sprintf(',\n'));
    end
  end
end

fclose(out_file);

exit;
