class FjuCrawler
  include XDDCrawler::ASPEssential

  def initialize(year: (Time.now.month.between?(1, 7) ? Time.now.year - 1 : Time.now.year),
                 term: (Time.now.month.between?(2, 7) ? 2 : 1))
    @year = year
    @term = term

    @courses = []
  end

  def course
    visit "http://estu.fju.edu.tw/fjucourse/firstpage.aspx"
    submit "依基本開課資料查詢"

    post @current_url, get_view_state.merge({
      "__EVENTTARGET" => "DDL_AvaDiv",
      "DDL_AvaDiv" => "C",
      "DDL_Section_S" => "",
      "DDL_Section_E" => "",
    })

    submit "查詢（Search）", {
      "DDL_AvaDiv" => 'C',
      "DDL_Avadpt" => "All-全部",
      "DDL_Class" => '',
      "DDL_Section_S" => '',
      "DDL_Section_E" => '',
    }

    @doc.css('#GV_CourseList').xpath('tr[position()>1]').each_with_index do |row, index|
      datas = row.css('td')

      # a sub course, has main course code
      next if not datas[2].text.gsub(/[^a-zA-Z0-9]/,'').empty?

      periods = []
      periods.concat parse_period(datas[12] && datas[12].text, datas[13] && datas[13].text, datas[14] && datas[14].text)
      periods.concat parse_period(datas[15] && datas[15].text, datas[16] && datas[16].text, datas[17] && datas[17].text)
      periods.concat parse_period(datas[18] && datas[18].text, datas[19] && datas[19].text, datas[20] && datas[20].text)
      periods.each_with_index {|d,i| periods.delete_at(i) if d.nil? }

      @courses << {
        # serial_no: datas[0].text.to_i,
        code: datas[1] && datas[1].text.strip,
        # department: datas[3].text,
        # department_code: datas[1].text.strip[0..2],
        name: row.css("td #GV_CourseList_Lab_Coucna_#{index}")[0].text,
        # eng_name: row.css("td #GV_CourseList_Lab_Couena_#{index}")[0].text,
        credits: datas[6] && datas[6].text.to_i,
        required: datas[7] && datas[7].text == '必',
        # full_semester: datas[8].text == '學年',
        lecturer: datas[9] && datas[9].text,
        # language: datas[10].text,
        periods: periods,
      }
    end
    $redis.set("course", JSON.pretty_generate(@courses))
    puts @courses[1..3]
    # binding.pry
    # File.open('public/courses.json', 'w') {|f| f.write(JSON.pretty_generate(@courses))}
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
end
