directory("bin", force: true, mode: :preserve)

directory("public", force: true)

directory("spec", force: true, exclude_pattern: /template.rb/)
