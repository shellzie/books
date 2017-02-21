require 'mechanize'
require 'open-uri'

class BooksController < ApplicationController
  def show
    scrape_amazon
    render text: "OK"
  end

  private

  def scrape_amazon
    local_image_path = '/Users/mkam/books/app/assets/images/'
    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'

    #LISTINGS PAGE 'Children's Books' -> 'Ages 3-5yrs'
    page = agent.get('https://www.amazon.com/b/ref=s9_acss_bw_cg_CHP8P_2b1_w?node=2578999011')
    doc = Nokogiri::HTML(page.content)
    results = doc.css('div#search-results div#mainResults ul li')

    results.each do |book|
      hash = {}
      title = book.css("a.s-access-detail-page h2").text
      hash = hash.merge({"title" => title})

      Rails.logger.debug "+++++++++++++++ " + title + "+++++++++++++++++\n\n"

      formatted_title = title.split(" ").join("_")
      image_url = book.css('div.a-col-left img')[0]["src"]
      download = open(image_url)
      open(local_image_path+formatted_title+".jpg", 'w')
      IO.copy_stream(download, local_image_path+formatted_title+".jpg")

      hash = hash.merge({"image_path" => formatted_title+".jpg"})

      details_url = book.css('div.a-col-right div.a-spacing-small a.s-access-detail-page')[0]["href"]
      details_page = agent.get(details_url)
      doc = Nokogiri::HTML(details_page.content)

      author = doc.css('span.author a')[0].text
      hash = hash.merge({"author" => author})
      price = doc.css("div#formats ul li span.a-color-price").text.strip
      hash = hash.merge({"price" => price})
      description = doc.css("div#bookDescription_feature_div noscript").text.strip
      hash = hash.merge({"description" => description})

      product_bullets = doc.css("div#detail-bullets div.content > ul > li")

      product_bullets.each do |item|
        pair = item.text.split(":")
        key = pair[0].strip
        if !key.include?("Customer Review") && !key.include?("Language") #throw away these items
          if key.include?("Best Sellers")
            list_items = item.css("ul.zg_hrsr li")
            categories = get_tags_array(list_items)
            hash_elt = {"tags" => categories}
          else
            val = pair[1].strip
            hash_elt = format_product_detail_value(key, val)
          end
          hash = hash.merge(hash_elt)
        end
      end

      do_insert(hash)
    end
  end

  #params is a hash of key, value pairs
  def do_insert(params)
    #check if record exists
    Book.create(params)
  end

  def get_tags_array(list_items)
    categories = []
    list_items.each do |item|
      links = item.css("span.zg_hrsr_ladder a")
      num_levels = links.length
      for i in 2..num_levels-1
        categories << links[i].text
      end
    end
    return categories
  end

  def format_product_detail_value(key, value)

    case key
      when "Age Range"
        elts = value.split(" ")
        val = elts[0] + elts[1] + elts[2]
        {"age" => val}
      when "Grade Level"
        elts = value.split(" ")
        val = elts[0] + elts[1] + elts[2]
        {"grade" => val}
      when "Hardcover"
        num_pages = value.split(" ")[1]
        {"cover_type" => "hard", "pages" => num_pages}
      when "Paperback"
        num_pages = value.split(" ")[1]
        {"cover_type" => "paper", "pages" => num_pages}
      when "Series"
        {"series" => value}
      when "Board book"
        {"cover_type" => "board", "pages" => value}
      when "Publisher"
        sections = value.split("(")
        val = sections[0].strip
        date = sections[1].slice(0, sections[1].length-1)
        {"publisher" => val, "publish_date" => date}
      when "Lexile Measure"
        val = value.split(" ")[0]
        {"lexile" => val}
      when "ISBN-10"
        {"ISBN10" => value}
      when "ISBN-13"
        {"ISBN13" => value}
      when "Product Dimensions"
        {"dimensions" => value}
      when "Shipping Weight"
        elts = value.split(" ")
        unit = elts[1]
        units = ""
        if (unit == "ounces" || unit == "ounce")
          units = "oz"
        elsif (unit == "pounds" || unit == "pound")
          units = "lbs"
        else
          puts "error parsing shipping weight"
        end
        result = elts[0] + " " + units
        {"weight" => result}
      when "Amazon Best Sellers Rank"
      else
        print('Case is key: ' + key + ' and value: ' + value + ' It is not a recognized label for Product Details')
    end

  end

  def books_params
    params.require(:book).permit(:title, :author, :publish_date)
  end


end
