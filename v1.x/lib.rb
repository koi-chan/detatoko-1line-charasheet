# @param [String] num 整数(1桁もしくは2桁)
# @result [String] 1桁なら全角に、2桁なら半角の整数
def unify_dispsize2(num)
  case num.size
  when 1
    num.half_to_full
  when 2
    num.full_to_half
  end
end

class String
  # 数字を全角に変換する
  def half_to_full
    self.tr('0-99', '０-９')
  end

  # 数字を半角に変換する
  def full_to_half
    self.tr('０-９', '0-9')
  end

  # 文字列を表示するために使うサイズを返す
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
  # @param long [Fixnum] 生成文字列の長さ
  # @param dot [Boolean] 末尾に … を付加するか
  # @return [String]
  def dispsize_cut(long, dot = false)
    return self if self.dispsize <= long

    result = ''
    nowlong = 0
    chars = self.chars
    nowlong += 2 if dot

    chars.each { |char|
      if (nowlong += char.dispsize) <= long
        result << chars.shift
      end
    }

    result << '…' if dot
    result << ' ' unless result.dispsize == long
    result
  end
end
