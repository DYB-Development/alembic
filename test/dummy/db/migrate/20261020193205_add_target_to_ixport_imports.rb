class AddTargetToIxportImports < ActiveRecord::Migration[8.1]
  def change
    add_reference :ixport_imports, :target, polymorphic: true, null: true
  end
end
