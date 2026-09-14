module KeystoneUi
  module React
    module MountHelper
      def react_ui(name, props = {}, data: {}, **attributes)
        tag.div(**attributes, data: data.merge(react_ui: name, props: props.to_json))
      end
    end
  end
end
