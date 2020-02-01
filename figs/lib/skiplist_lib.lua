local luamp = require 'luamp'
local stream = require 'stream'
local table = require 'table'

local ret = {}

function ret.draw_doc_chain(outs, start_pt, ts)
    local ps = stream
        .iterate(
            start_pt,
            function(x)
                return x + luamp.point(1, 0)
            end)
        :take(#ts)
        :collect()
    stream
        .zip(
            stream.from_list(ps),
            stream.from_list(ts))
        :map(function(x)
            return luamp.text(x[1], luamp.directions.center, x[2])
        end)
        :collect(outs)
    local bcircles = stream.from_list(ps)
        :map(function(x)
            return luamp.circle(x, 0.2)
        end)
        :collect()
    stream.from_list(bcircles):collect(outs)
    stream
        .zip(
            stream.from_list(bcircles),
            stream.from_list(bcircles):drop(1))
        :map(function(x)
            return luamp.arrow(x[1], x[2])
        end)
        :collect(outs)

    local level_n = math.log(#ts, 2)
    local height = level_n * 0.5 + 0.3
    stream.from_list(bcircles)
        :map(function(x)
            return luamp.line(x, x:center() + luamp.point(0, height), {line_style=luamp.line_styles.dashed})
        end)
        :collect(outs)
    local height = 0.6
    local skip = 2
    while skip <= #ts do
        local xs = stream.from_list(bcircles)
            :enumerate()
            :filter(function(x)
                if x[1] % skip == 1 then
                    return true
                else
                    return false
                end
            end)
            :map(function(x)
                return x[2]
            end)
            :collect()
        stream
            .zip(
                stream.from_list(xs),
                stream.from_list(xs):drop(1))
            :map(function(x)
                return luamp.arrow(
                    x[1]:center() + luamp.point(0, height),
                    x[2]:center() + luamp.point(0, height))
            end)
            :collect(outs)
        height = height + 0.5
        skip = skip * 2
    end
    return bcircles
end

return ret
