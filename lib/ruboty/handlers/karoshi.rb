module Ruboty
  module Handlers
    class Karoshi < Base
      NAMESPACE = 'karoshi'

      on %r|(?<n_hours>[\d])時間残業します|, description: '発言者の残業が申請されます', name: :n_hours_application
      on %r|残業申請者一覧|, description: '残業者を取得します', name: :show_list

      def n_hours_application(message)
        from = message.original[:from]
        n_hours = message[:n_hours].to_i
        write(from: from, n_hours: n_hours)
        message.reply("#{n_hours}時間ですね。残業頑張ってください")
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
        robot.brain.data[NAMESPACE][today][from] ||= {n_hours: n_hours}
      end

      def read
        data = robot.brain.data[NAMESPACE] || {}
        data[Date.today] || {}
      end
    end
  end
end
