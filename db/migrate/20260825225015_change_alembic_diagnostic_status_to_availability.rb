class ChangeAlembicDiagnosticStatusToAvailability < ActiveRecord::Migration[8.1]
  class Diagnostic < ActiveRecord::Base
    self.table_name = "alembic_diagnostics"
  end

  def up
    Diagnostic.update_all(status: "active")
    change_column_default :alembic_diagnostics, :status, "active"
    change_column_null :alembic_diagnostics, :status, false, "active"
  end

  def down
    change_column_null :alembic_diagnostics, :status, true
    change_column_default :alembic_diagnostics, :status, nil
  end
end
