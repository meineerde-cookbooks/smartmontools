module Smartmontools
  # Helper methods used in the rendered templates of this cookbook
  # this module can be included
  module TemplateHelpers
    def device_opts_with_default(opts=[])
      opts = Array(opts)
      opts.empty? ? node['smartmontools']['device_opts'].dup : opts
    end

    def device_opts(opts=[])
      addrs = Array(node['smartmontools']['email_addresses'])
      existing_addrs = []

      opts = device_opts_with_default(opts).reject do |opt|
        if opt =~ /^\s*-m(\s+|$)/
          existing_addrs += opt.sub(/^\s*-m\s*/, '').split(',').map(&:strip)
        end
      end
      opts << "-m #{(existing_addrs + addrs).join(',')}"
    end
  end
end
