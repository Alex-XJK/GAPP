Rails.application.configure do

  config.hosts << ".ngrok.io"

  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Prevent overwriting the existing attachments
  config.active_storage.replace_on_assign_to_many = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker

    # Custom configuration
  # 原分析流程输出路径
  config.task_output_dir = '/home/caronkey/'
  # 生成报告python环境
  config.python_env = '/disk2/apps/custom_library/python/bin/'
  config.custom_storage = Rails.root.join('storage/custom')
  # 分析流程相关
  config.flow_smart_template = "#{config.custom_storage}/json_file/template/flow_smart/"
  config.flow_smart_result = "#{config.custom_storage}/json_file/result/flow_smart/"
  config.bio_task_result = "#{config.custom_storage}/bio_task_result/"
  config.bio_task_sample_csv = "#{config.custom_storage}/bio_task_sample_csv/"
  # 生成报告相关
  # config.generate_report_template = "#{config.custom_storage}/json_file/template/generate_report/"
  # config.generate_report_result = "#{config.custom_storage}/json_file/result/generate_report/"
  config.generate_report_template = '/home/platform/exps_test/'
  config.generate_report_result = '/home/platform/infresTest/'
  config.html_report_out = '/home/platform/exps_test/output/child/html'
  config.pdf_report_out = '/home/platform/exps_test/output/child/pdf'
  config.infres_main = "#{Rails.configuration.python_env}/infres process  -i"
  config.exps_main = "#{Rails.configuration.python_env}/exps  -i"
  config.template_loader_path = '/home/platform/exps_test/report/templates/'
  # 产品相关
  config.product_operator = "#{config.custom_storage}/operator"

  # 临时中转文件
  config.tmp_zip = 'tmp/zip'
  config.tmp_panel = 'tmp/panel'
  config.tmp_operator = 'tmp/operator'
end
