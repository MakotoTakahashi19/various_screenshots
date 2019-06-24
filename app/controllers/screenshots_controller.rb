class ScreenshotsController < ApplicationController
  def index
  end

  def shot
    if params[:url] == ""
      redirect_to root_path
      # TODO アラート出す
    else
      require 'selenium-webdriver'
      require 'webdriver-user-agent'
      require 'rmagick'
      # UserAgent選択
      case params[:agent]
      when "pc" then
        driver = Selenium::WebDriver.for :chrome
      when "iphone" then
        driver = Webdriver::UserAgent.driver(
        :browser     => :chrome,
        :agent       => :iphone,
        :orientation => :portrait)
      when "android_phone" then
        driver = Webdriver::UserAgent.driver(
        :browser     => :chrome,
        :agent       => :android_phone,
        :orientation => :portrait)
      end
      count = 1
      urls = params[:url].rstrip.split(/\r?\n/).map {|line| line.chomp }
      urls.each do |url|
        # 指定のウィンドウサイズに変更
        if params[:fullsize] == "on"
          driver.manage().window().maximize();
        else
          driver.manage.window.resize_to(params[:width].to_i, params[:height].to_i)
        end

        driver.get(url)

        # Javascriptで画面のサイズを取得
        inner_h = driver.execute_script("return window.innerHeight").to_i
        inner_w = driver.execute_script("return window.innerWidth").to_i
        scroll_h = driver.execute_script("return document.documentElement.scrollHeight").to_i

        repeat = (scroll_h.to_f/inner_h.to_f).ceil
        dupl_h = scroll_h % inner_h #被りの高さ

        tmp_fnames = []

        # file名の指定
        if params[:name] == "number"
          name = count
          tmp_basename = name.to_s
          count += 1
        else
          tmp_basename = url
        end

        # スクロールしながらキャプチャ
        repeat.times{|i|
          tmp_fnames << tmp_fname = tmp_basename + sprintf("%06d",i) + ".png"
          sleep (params[:ragtime].to_i) if params[:ragtime].to_i > 0
          driver.save_screenshot(tmp_fname)
          driver.execute_script("window.scrollBy(0,#{inner_h})")
        }

        if tmp_fnames.length > 1
          #一時ファイルが2つ以上の場合
          # 最後の一枚のみ重複ができるのでMiniMagickを使ってカット
          if dupl_h > 0
            image = Magick::ImageList.new(tmp_fnames.last)
            last_image = image.crop(Magick::SouthWestGravity, inner_w*2, dupl_h*2)
            last_image.write(tmp_fnames.last)
          end
          #4. ImageMagickを使って全ての画像を結合
          `convert -append #{tmp_fnames.join(' ')} #{tmp_basename}.jpg`

          File.unlink *tmp_fnames
        else
          #1つの場合は一時ファイルをリネームするだけ
          File.rename(tmp_fnames[0],"#{tmp_basename}.jpg")
        end
      end
      driver.quit
      # zipファイルへ変換
      # ダウンロード機能の追加
      # send_file("#{tmp_basename}.jpg")
      redirect_to root_path
    end
  end
end
