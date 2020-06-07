# coding: UTF-8

class String
  # 数字を全角に変換する
  # @return [String]
  def half_to_full
    self.tr('0-9', '０-９')
  end

  # 数字を半角に変換する
  # @return [String]
  def full_to_half
    self.tr('０-９', '0-9')
  end

  # 文字列を表示するために使うサイズを返す
  # @return [Integer]
  def dispsize
    charsize = 0

    self.each_char do |char|
      if char.bytesize > 1
        charsize += 2
      else
        charsize += 1
      end
    end

    charsize
  end

  # 表示サイズに文字列を切り詰める
  # @param long [Integer] 生成文字列の長さ
  # @param dot [Boolean] 末尾に … を付加するか
  # @return [String]
  def dispsize_cut(long, dot = false)
    return self if self.dispsize <= long
    
    result = ''
    chars = self.chars
    nowlong = dot ? 2 : 0
    
    chars.each { |char|
      if (nowlong += char.dispsize) <= long
        result << char
      end
    }

    result << '…' if dot
    result << ' ' unless result.dispsize == long
    result
  end

  # 指定した長さに丸めたり末尾に空白を挿入したりする
  # @return [String]
  def dispformat(target)
    long = self.dispsize
    case long
    when 1..target - 1
      self + ' ' * (target - long)
    when target
      self
    else
      self.dispsize_cut(target, true)
    end
  end
end
