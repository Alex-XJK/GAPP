class AdminController < ApplicationController
    before_action :authenticate_account!
    before_action :require_admin

    # http_basic_authenticate_with name: "gappdev", password: "hyqxjkzx"
    $abd_dir = "#{Rails.root}/app/data/abd_files/"
    def index
        @projects = App.order(:name)
        @ana_cate = Analysis.order(:name)
        @ac_attrs = Analysis.column_names
        @viz = Task.order(:name)
        @viz_attrs = Task.column_names
        @ana = Analysis.order(:name)
        @a_attrs = Analysis.column_names

        @users = User.select(:id, :username, :created_at)
        @usercolumn = ["id", "username", "created_at"] 

        @usercnt = User.count
        @catcnt = Category.count
        @appcnt = App.count
        @taskcnt = Task.count
        @rolecnt = Role.count
        @ruby_ver = RUBY_VERSION
        @acccnt = Account.count
    end

    def require_admin
        unless account_signed_in? and current_account.has_role? :admin
          flash[:error] = "You must be an admin to access this page. (Current role: " + current_account.roles.first.name + ")"
          redirect_to "/" # halts request cycle
        end
    end

    def modify_sample_abd
        #redirect_to import_abd_table_project_samples_path(:project_id=>params[:project_id], :file=>params[:file])
        @project = Project.find(params[:project_id])
        n1 = @project.name
        up_file = params[:file]
        # uploader = AbdUploader.new(n1)
        # uploader.store!(up_file)
        if up_file.respond_to?(:read)
            data = up_file.read
            lines = data.split("\n")
            names = lines[0].chomp.split("\t")
            n_sample = names.length() - 1
            pj_name = names[0]
            s_names = names[1..n_sample]
            i = 1
            all_json = {}
            while i < lines.length()
                line = lines[i]
                buffer = line.split("\t")
                key = buffer[0].chomp
                all_json[key] = Array.new(n_sample, "NA")
                for j in 1..n_sample
                    v = buffer[j].chomp
                    all_json[key][j-1] = v
                end
                i += 1
            end

            keys = all_json.keys
            s_names.each_with_index do |s_name, index|
                f_path = "#{$abd_dir}#{n1}_#{s_name}.tsv"
                f = File.open(f_path, "w")
                s = "#{n1}\t#{s_name}"
                i = index
                keys.each do |k|
                    value = all_json[k][i]
                    if value.to_f != 0
                        s += "\n"
                        s += "#{k}\t#{value}"
                    end
                end
                f.write(s)
                f.close
            end

        else
            logger.error "Bad file_data: #{up_file.class.name}: #{up_file.inspect}"
        end
        redirect_to '/admin', notice: "ALL Abundance data uploaded."
    end

    def update_all_samples
        Sample.import(params[:file])
        redirect_to '/admin', notice: "Samples imported."
    end

    def modify_viz
        Visualizer.import(params[:file])
        redirect_to '/admin', notice: "Visualization imported."
    end

    def modify_ana_cate
        AnalysisCategory.import(params[:file])
        redirect_to '/admin', notice: "Analysis category imported."
    end
    
    def modify_ana
        Analysis.import(params[:file])
        redirect_to '/admin', notice: "Analysis module imported."
    end

    def add_img
        file = params[:image_file]
        @filename = file.original_filename
        File.open("#{Rails.root}/app/assets/images/#{@filename}", "wb") do |f|
            f.write(file.read)
        end
        redirect_to '/admin', notice: "Image added."

    end

    def modify_viz_source
        VizDataSource.import(params[:file])
        redirect_to '/admin', notice: "Visualization source imported."
    end
    

end
