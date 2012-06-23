# coding: utf-8
module TiebaXiaoshuoBot
  require 'tieba_xiaoshuo_bot/patch/rexml_utf_patch'
  require 'tieba_xiaoshuo_bot/patch/standard_error'
  require 'xmpp4r/client'
  require 'xmpp4r/roster'
  class Bot
    @@myJID = Jabber::JID.new("crhan.xiaoshuo@gmail.com")
    @@myPassword = 'GefEnsAnift('
    def initialize
      connect
      auto_update_roster_item
      auto_accept_subscription_resquest
      add_message_callback
    end

    def cl
      @@cl
    end

    # receive an User object and an array of CheckList objects
    def sendMsg user, content
      # find the user account send to
      send_to = if user.instance_of? User
             user.account
           elsif user.instance_of? String
             user
           elsif user.instance_of? Fixnum
             User.find(:id => user).account
           end
      msg = Jabber::Message.new(send_to).set_type("chat")
      if content.instance_of? Array
        content.each do |e|
          @@instance.reconnect
          @@cl.send(msg.set_body(e.to_s))
          $logger.info %|Send Message to "#{send_to}", with "#{e.to_s}"|
        end
      elsif content.instance_of? String
        @@instance.reconnect
        @@cl.send(msg.set_body(content))
        $logger.info %|Send Message to "#{send_to}", with "#{content}"|
      end
    end

    def auth
      @@cl.connect
      @@cl.auth(@@myPassword)
      # set online
      @@cl.send(Jabber::Presence.new)
      $logger.info "Connected ! send messages to #{@@myJID.strip.to_s}."
    end

    def connect
      # loggin to gtalk server
      # Jabber::debug = true
      @@cl = Jabber::Client.new(@@myJID)
      auth
      # get the roster
      @@roster = Jabber::Roster::Helper.new(@@cl)
    end

    def reconnect
      if @@cl.is_disconnected?
        @@instance.auth
        true
      else
        false
      end
    end

    def is_disconnected?
      @@cl.is_disconnected?
    end

    def close
      @@cl.close
    end

    private

    def auto_update_roster_item
      # register the exist subscription to User model
      @@roster.add_query_callback do |r|
        @@roster.items.each do |k,v|
          # create user if not exist
          jid = v.jid.strip.to_s
          user = User.find_or_create(:account => jid)
          $logger.debug "user #{jid} found in rosterItem"
        end
      end
    end

    def auto_accept_subscription_resquest
      # accept any of the XMPP subscription request
      @@roster.add_subscription_request_callback do |item,presence|
        @@roster.accept_subscription(presence.from)
        # send back subscription request
        @@cl.send(Jabber::Presence.new.set_type(:subscribe).set_to(presence.from))
        # greating to the new friend
        @@cl.send(Jabber::Message.new(presence.from, "hello, my new friend~").set_type("chat"))
        $logger.info "accept roster subscription from #{presence.from.to_s}"
        User.find_or_create(:account => prensence.from.strip.to_s)
      end
    end

    def add_message_callback
      @@cl.add_message_callback do |m|
        if m.type = :chat and !m.body.nil?
          user = User.find_or_create(:account => m.from.strip.to_s)
          # TODO parse body
          $logger.debug %|--start parsing "#{m.body}" from user "#{user.account}"|
          parse_msg m.body, user
          $logger.debug %|--stop parsing "#{m.body}" from user "#{user.account}"|
        end
      end
    end

    def parse_msg msg, user
      if msg[0].eql? '-' # it is a command
        $logger.debug %|found command "#{msg}"|
        # continue parsing
        comm = msg[1..-1]
        $logger.debug %|parsing command is "#{comm}"|
        case comm
        when /^sub[\s ]/ # subscription request
          Worker::Sub.perform_async comm, user.id
        when /^unsub[\s ]/ # unsubscription request
          Worker::UnSub.perform_async comm, user.id
        when /^list.*/
          sendMsg user,user.list_subscriptions
        else # what's this?
          # send default message
          binding.pry
          raise ArgumentError, comm
        end
      else # what's this?
        # send default message
        raise TypeError, msg
      end
    rescue ArgumentError => e
      Worker::LogError.perform_async self, e.message
      sendMsg user, %|what do you mean by sending "#{e.message}" to me?|;
    rescue TypeError => e
      Worker::LogError.perform_async self, e.message
      sendMsg user, e.message
    end

    public
    @@instance = Bot.new

    def self.instance
      return @@instance
    end

    private_class_method :new
  rescue IOError => e
    @@instance.reconnect
    sleep 2
    retry
  end
end