require 'mechanize'

class BooksController < ApplicationController


  def show
    scrape_amazon
    render text: "OK"
  end

  private

  def scrape_amazon

    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'
    # page = agent.get('https://www.amazon.com')
    # search_form = page.form('site-search')
    # search_form['field-keywords'] = 'picture books for children 3-5'
    # page = agent.submit(search_form)


    #LISTINGS PAGE 'Children's Books' -> 'Ages 3-5yrs'
    page = agent.get('https://www.amazon.com/b/ref=s9_acss_bw_cg_CHP8P_2b1_w?node=2578999011')
    doc = Nokogiri::HTML(page.content)
    results = doc.css('div#search-results div#mainResults ul li')

    results.each do |book|
      image_src = book.css('div.a-col-left img')[0]["src"]
      #download image and save it
      details_url = book.css('div.a-col-right div.a-spacing-small a.s-access-detail-page')[0]["href"]
      details_page = agent.get(details_url)
      doc = Nokogiri::HTML(details_page.content)

      #DETAILS PAGE
      hash = {}
      title = doc.css('span#productTitle')
      hash.merge({"title" => title})
      author = doc.css('span.author span.a-declarative a')[0].text
      hash.merge({"author" => author})
      price = doc.css("div#formats ul li span.a-color-price").text.strip
      hash.merge({"price" => price})
      description = doc.css("div#bookDescription_feature_div noscript").text.strip
      hash.merge("description" => description)


      product_bullets = doc.css("div#detail-bullets div.content > ul > li")
      product_bullets.each do |item|
        pair = item.text.split(":")
        key = pair[0].strip
        if !key.include?("Customer Review") && !key.include?("Language")
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
        {"cover_type" => "hard", "pages" => value}
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
        {"ISBN-10" => value}
      when "ISBN-13"
        {"ISBN-13" => value}
      when "Product Dimensions"
        {"dimensions" => value}
      when "Shipping Weight"
        elts = value.split(" ")
        unit = elts[1]
        if unit == "ounces" || unit == "ounce"
          units = "oz"
        elsif unit == "pounds" || unit == "pound"
          units = "lbs"
        end
         result = elts[0] + " " + units
        {"weight" => result}
      when "Amazon Best Sellers Rank"
      else
        print('It is not a recognized label for Product Details')
    end

  end

  def books_params
    params.require(:book).permit(:title, :author, :publication_date, :isbn)
  end


end
