module KeystoneUi
  module React
    module MountHelper
      def react_ui(name, props = {})
        tag.div(data: { react_ui: name, props: props.to_json })
      end
    end
  end
end
