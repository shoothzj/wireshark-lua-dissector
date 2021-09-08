bk_protocol = Proto("Bookkeeper", "Bookkeeper Protocol")

message_length = ProtoField.int32("bk.message_length", "messageLength", base.DEC)

bk_protocol.fields = {message_length}

local protobuf_dissector = Dissector.get("protobuf")

function bk_protocol.dissector(buffer, pinfo, tree)
    local offset = 0
    local remaining_len = buffer:len()
    local subtree = tree:add(bk_protocol, buffer(), "Bookkeeper Protocol Data")
    pinfo.cols.protocol = bk_protocol.name
    while remaining_len > 0 do
        if remaining_len < 4 then
            -- head not enough
            pinfo.desegment_offset = offset
            pinfo.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
            return -1
        end
        local data_len = buffer(offset, 4):uint()
        if remaining_len - 4 < data_len then
            -- data not enough
            pinfo.desegment_offset = offset
            pinfo.desegment_len = data_len - (remaining_len - 4)
            return -1
        end
        subtree:add(message_length, buffer(offset, 4))
        if pinfo.dst_port == 3181 then
            pinfo.private["pb_msg_type"] = "message,Request"
            pcall(Dissector.call, protobuf_dissector, buffer(offset + 4, data_len):tvb(), pinfo, subtree)
        else
            pinfo.private["pb_msg_type"] = "message,Response"
            pcall(Dissector.call, protobuf_dissector, buffer(offset + 4, data_len):tvb(), pinfo, subtree)
        end
        offset = offset + 4 + data_len
        remaining_len = remaining_len - 4 - data_len
    end
end

local tcp_port = DissectorTable.get("tcp.port")
tcp_port:add(3181, bk_protocol)
