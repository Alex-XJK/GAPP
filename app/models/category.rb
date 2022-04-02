class Category < ApplicationRecord
    after_create :assign_initial_serial

    def assign_initial_serial
        self.serial = "1"
        self.initial = ""
        for word in String(self.name).split() do
            self.initial += word[0].upcase
        end
        self.save()
    end
end
