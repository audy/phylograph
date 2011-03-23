# A matrix that makes sense to humans

class Matrice
  def initialize(x, y, v=nil)
    @matrix = Array.new
    (0..y).each do |j|
      @matrix[j] = Array.new
      (0..x).each do |i|
        @matrix[j][i] = v
      end
    end
  end

  def set_row(n, a)
    @matrix[n] = a
  end

  def set_column(n, a)
    @matrix.each_with_index do |row, index|
      row[n] = a[index]
    end
    @matrix
  end

  def [](i, j)
    @matrix[j][i]
  end

  def []=(i, j, v)
    @matrix[j][i] = v
  end

  def get_row(n)
    @matrix[n]
  end

  def get_column(n)
    column = []
    @matrix.each do |row|
      column << row[n]
    end
    column
  end

  def to_s
    s = ''
    @matrix.each do |row|
      s << row.join(' ')
      s << "\n"
    end
    s
  end
end