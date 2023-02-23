//--------------------------------------------------------------------------------------------------------------------------------
// name : raxi_seqi
//--------------------------------------------------------------------------------------------------------------------------------
class raxi_seqi extends uvm_sequence_item;
    `uvm_object_param_utils(raxi_seqi)
    `uvm_object_new

    extern function string convert2string();
    extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);

    bit reset;
    bit valid;
    bit first;
    bit last;
    bit keep;
    bit ready;
    bit data[];
    bit user[];
    bit id[];
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function string raxi_seqi::convert2string();
    string s;

    s = $sformatf("valid = %0d", valid);
    s = {s, $sformatf("last = %0d", last)};
    s = {s, $sformatf("ready = %0d", ready)};
    if (data.size > 0)
        s = {s, $sformatf("\ndata = %0p", data)};
    if (user.size > 0)
        s = {s, $sformatf("\nuser = %0p", user)};
    if (id.size > 0)
        s = {s, $sformatf("\nuser = %0p", id)};

    return s;
endfunction

function bit raxi_seqi::do_compare(uvm_object rhs, uvm_comparer comparer);
    raxi_seqi RHS;
    bit same;

    same = super.do_compare(rhs, comparer);

    $cast(RHS, rhs);
    same = same && (valid == RHS.valid);
    if (data.size > 0)
        same = same && (data == RHS.data);
    if (user.size > 0)
        same = same && (user == RHS.user);
    if (id.size > 0)
        same = same && (id == RHS.id);

    return same;
endfunction