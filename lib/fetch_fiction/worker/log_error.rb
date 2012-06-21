# coding: utf-8

module FetchFiction
  class LogError
    include Sidekiq::Worker

    def perform err_class, msg
      new_e = Error.create(:class => err_class, :msg => msg)
      $logger.info "errorLog created by :class => #{err_class}, :msg => #{msg}"
    end
  end
end
