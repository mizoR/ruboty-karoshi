module Ruboty
  module Handlers
    class Karoshi < Base
      NAMESPACE = 'karoshi'
      STRTONUM = {
        '一'=>'1', '二'=>'2', '三'=>'3', '四'=>'4', '五'=>'5', '六'=>'6', '七'=>'7', '八'=>'8', '九'=>'9',
        '１'=>'1', '２'=>'2', '３'=>'3', '４'=>'4', '５'=>'5', '６'=>'6', '７'=>'7', '８'=>'8', '９'=>'9',
      }

      on %r|(?<n_hours>.+)時間(?<half_an_hour>半)?残業します|, description: '発言者の残業が申請されます', name: :n_hours_application
      on %r|(?<n_hours>.+)時間(?<half_an_hour>半)?残業しました|, description: '発言者の残業が申請を却下します', name: :reject_application
      on %r|残業申請者?一覧|, description: '残業申請一覧を表示します', name: :show_list

      def n_hours_application(message)
        from = message.original[:from]
        n_hours = message[:n_hours]
        n_hours = n_hours.gsub(/#{STRTONUM.keys.join('|')}/) {|k| STRTONUM[k]}
        n_hours = n_hours.to_f
        n_hours += 0.5 if message[:half_an_hour].to_s != ''
        write(from: from, n_hours: n_hours)
        message.reply("#{n_hours}時間ですね。残業頑張ってください")
      end

      def reject_application
        message.reply("事後申請は受け付けておりません、ちゃんと事前に申請しましょう(｀・ω・´)ｷﾘｯ")
      end

      def show_list(message)
        if workers = read
          workers.each do |worker, data|
            message.reply("#{worker}: #{data[:n_hours]}時間")
          end
        else
          message.reply("残業する人はいません。")
        end
      end

      private

      def write(from: from, n_hours: n_hours)
        today = Date.today

        robot.brain.data[NAMESPACE] ||= {}
        robot.brain.data[NAMESPACE][today] ||= {}
        robot.brain.data[NAMESPACE][today][from] = {n_hours: n_hours}
      end

      def read
        data = robot.brain.data[NAMESPACE] || {}
        data[Date.today] || {}
      end
    end
  end
end
