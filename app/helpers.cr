def bytes_to_human(n : Int64) : String
  units = %w[b kb mb gb tb pb]
  base = 1024

  if n < base
    return "#{n} #{units[0]}"
  end

  exp = (Math.log(n) / Math.log(base)).to_i
  max_exp = units.size - 1
  exp = max_exp if exp > max_exp

  size = n.to_f / (base**exp).to_f
  return "%.2f %s" % [size, units[exp]]
end

macro render_page(filename)
  render "app/views/#{ {{filename}} }.ecr", "app/views/layouts/layout.ecr"
end
