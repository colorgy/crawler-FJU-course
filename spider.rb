require 'json'
require 'logger'
require 'capybara/poltergeist'

class Spider
  include Capybara::DSL
  attr_reader :progress

  def initialize
    Capybara.register_driver :poltergeist_debug do |app|
      Capybara::Poltergeist::Driver.new(app,
        {
          inspector: true,
        }
      )
    end

    Capybara.current_driver = :poltergeist_debug
    Capybara.javascript_driver = :poltergeist_debug

    @done = false
    @last_used = nil
    @logger = Logger.new(STDOUT)
    @running = false
  end

  def start(force: false)
    # if has crawl in last 2 hours and has file
    return if @last_used && ((Time.now - @last_used) > 7200) && !force && @done || @running

    Thread.start do
      @running = true
      @done = false
      crawl_task
    end
  end

  def crawl_task
    @logger.info('run crawl_task!')
    @progress = "task start!"
    page.visit "http://estu.fju.edu.tw/fjucourse/firstpage.aspx"
    page.click_on '依基本開課資料查詢'
    sleep 2
    @progress = "loading page..."
    page.all('select[name="DDL_AvaDiv"] option')[1].select_option
    sleep 3
    @logger.info("ready to click...")
    @logger.debug(find '查詢（Search）')
    page.click_on '查詢（Search）'
    parse(page.html)
  end

  def parse(html)
    courses = []
    # course_list = Nokogiri::HTML(File.read('courses.html'))
    @progress = "start parsing webpage..."
    course_list = Nokogiri::HTML(html)
    course_list.css('#GV_CourseList').css('tr[style="color:#330099;background-color:White;"]').each_with_index do |row, index|
      datas = row.css('td')

      # a sub course, has main course code
      next if not datas[2].text.gsub(/[^a-zA-Z0-9]/,'').empty?

      periods = []
      periods.concat parse_period(datas[12] && datas[12].text, datas[13] && datas[13].text, datas[14] && datas[14].text)
      periods.concat parse_period(datas[15] && datas[15].text, datas[16] && datas[16].text, datas[17] && datas[17].text)
      periods.concat parse_period(datas[18] && datas[18].text, datas[19] && datas[19].text, datas[20] && datas[20].text)
      periods.each_with_index {|d,i| periods.delete_at(i) if d.nil? }

      begin
        courses << {
          # serial_no: datas[0].text.to_i,
          code: datas[1] && datas[1].text.strip,
          # department: datas[3].text,
          # department_code: datas[1].text.strip[0..2],
          name: row.css("td #GV_CourseList_Lab_Coucna_#{index}")[0].text,
          # eng_name: row.css("td #GV_CourseList_Lab_Couena_#{index}")[0].text,
          credits: datas[6].text.to_i,
          required: datas[7].text == '必',
          # full_semester: datas[8].text == '學年',
          lecturer: datas[9].text,
          # language: datas[10].text,
          periods: periods,
        }
      rescue Exception => e
        binding.pry
      end
    end

    File.open('courses.json', 'w') {|f| f.write(JSON.pretty_generate(courses))}
    @done = true
    @last_used = Time.now
    @running = false
    puts "done!"
  end

  def parse_period(day, tim, loc)
    ps = []
    m = tim.match(/.(?<s>\d)\-.(?<e>\d)/)
    if !!m
      (m[:s].to_i..m[:e].to_i).each do |period|
        chars = []
        chars << day
        chars << period
        chars << loc
        ps << chars.join(',')
      end
    end
    return ps
  end

  def done?
    return @done
  end
end

# spider = Spider.new
# spider.start_crawl

