class ScreenshotsController < ApplicationController
  def index
  end

  def shot
    if params[:url] == ""
      redirect_to root_path
    else
      require 'selenium-webdriver'
      require 'webdriver-user-agent'
      driver = Webdriver::UserAgent.driver(:browser     => :chrome,
                                          :agent       => :iphone,
                                          :orientation => :portrait)
                                          # browser => :firefox(default)
                                          #            :chrome
                                          # agent => :iphone (default)
                                          #          :ipad
                                          #          :android_phone
                                          #          :android_tablet
                                          #          :random
                                          # :orientation => :portrait (default) 縦向き
                                          #                 :landscape 横向き
      # driver.get 'http://yahoo.co.jp' # スマホビューのYahoo!のサイトが表示される
      driver.get(params[:url])
      driver.save_screenshot("10.jpg")
      driver.quit
      redirect_to root_path
    end
  end
end
