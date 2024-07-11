#!/usr/bin/env ruby
# frozen_string_literal: true

# required for iOS 16 and below: https://github.com/rails/importmap-rails/pull/216
insert_into_file("app/views/layouts/application.html.erb", <<-ERB,
    <script async src="https://ga.jspm.io/npm:es-module-shims@1.8.2/dist/es-module-shims.js" data-turbo-track="reload"></script>
ERB
                 before: "    <%= javascript_importmap_tags %>\n")
