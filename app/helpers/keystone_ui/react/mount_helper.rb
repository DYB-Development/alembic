module KeystoneUi
  module React
    module MountHelper
      def react_ui(name)
        tag.div(data: { react_ui: name })
      end
    end
  end
end
