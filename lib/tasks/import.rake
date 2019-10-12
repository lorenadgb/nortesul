require 'csv'

namespace :import do
  desc 'Import fees from CSV file'

  task fees: :environment do
    CSV.foreach('./lib/files/fees.csv', headers: true) do |row|

      estado      = row['estado']
      residencial = row['residencial']
      comercial   = row['comercial']
      outro       = row['outro']

      record = State.where("lower(name) = ?", estado.downcase).first

      p "Sate: #{estado}"

      record.residencial = residencial.to_f / 100
      record.comercial   = comercial.to_f / 100
      record.outro       = outro.to_f / 100

      record.save
    end
  end
end
