class AddFeesFieldsToStates < ActiveRecord::Migration[5.2]
  def change
    add_column :states, :residencial, :decimal, precision: 8, scale: 2
    add_column :states, :comercial,   :decimal, precision: 8, scale: 2
    add_column :states, :outro,       :decimal, precision: 8, scale: 2
  end
end
