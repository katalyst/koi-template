copy_file("app/helpers/release_helper.rb")

insert_into_file("app/views/layouts/application.html.erb", "\t<%= release_meta_tags %>\n", :after => "</title>\n")
