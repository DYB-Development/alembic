class AddErrorMessageToIxportImports < ActiveRecord::Migration[8.1]
  def change
    add_column :ixport_imports, :error_message, :text
  end
end
