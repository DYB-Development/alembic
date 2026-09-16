module KsBlocks
  BlockType = Data.define(:key, :name, :width, :height, :min_width, :max_width, :min_height, :max_height) do
    def initialize(key:, name:, width:, height:, min_width: 1, max_width: nil, min_height: 1, max_height: nil)
      super
    end
  end
end
