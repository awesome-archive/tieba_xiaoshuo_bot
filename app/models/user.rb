# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  attr_accessible :account, :active, :send_count
end
