root = Pathname.new(__dir__).join("..")
root.glob("spec/support/**/*.rb").sort.each do |f|
  copy_file(f.relative_path_from(root), force: true)
end

root.glob("spec/*.rb").sort.each do |f|
  copy_file(f.relative_path_from(root), force: true)
end

root.glob("bin/*").sort.each do |f|
  copy_file(f.relative_path_from(root), force: true)
end

root.glob("public/*.{html,css}").sort.each do |f|
  copy_file(f.relative_path_from(root), force: true)
end
