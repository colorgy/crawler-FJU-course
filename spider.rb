require 'nokogiri'
require 'json'
require 'hashie'
require 'pry'

courses = []
course_list = Nokogiri::HTML(File.read('courses.html'))
course_list.css('#GV_CourseList').css('tr[style="color:#330099;background-color:White;"]').each_with_index do |row, index|
  cols = row.css('td')

  # a sub course, has main course code
  next if not cols[2].text.gsub(/[^a-zA-Z0-9]/,'').empty?

  begin
    courses << {
      serial_no: cols[0].text.to_i,
      code: cols[1].text.strip,
      department: cols[3].text,
      department_code: cols[1].text.strip[0..2],
      name: row.css("td #GV_CourseList_Lab_Coucna_#{index}")[0].text,
      eng_name: row.css("td #GV_CourseList_Lab_Couena_#{index}")[0].text,
      credits: cols[6].text.to_i,
      required: cols[7].text == '必',
      full_semester: cols[8].text == '學年',
      lecturer: cols[9].text,
      language: cols[10].text
    }
  rescue Exception => e
    binding.pry
  end
end

File.open('courses.json', 'w') {|f| f.write(JSON.pretty_generate(courses))}
