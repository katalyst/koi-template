root = Pathname.new(__dir__).join("..")
root.glob("spec/support/**/*.rb").sort.each do |f|
  copy_file(f.relative_path_from(root), force: true)
end

root.glob("spec/*_helper.rb").sort.each do |f|
  copy_file(f.relative_path_from(root), force: true)
end

copy_file("bin/setup", force: true)
root.glob("bin/ecs-*").sort.each do |f|
  template(f.relative_path_from(root), force: true)
  chmod f.relative_path_from(root), 0755
end

root.glob("public/*.{html,css}").sort.each do |f|
  copy_file(f.relative_path_from(root), force: true)
end
