`ifndef uvm_object_new
    `define uvm_object_new \
        function new (string name=""); \
            super.new(name); \
        endfunction : new
`endif

`ifndef uvm_object_create
    `define uvm_object_create(_type_name_, _inst_name_, _id_ = 0) \
        _inst_name_ = _type_name_::type_id::create($sformatf({`"_inst_name_`", "_%0d"}, _id_));
`endif

`ifndef uvm_component_new
    `define uvm_component_new \
        function new (string name="", uvm_component parent=null); \
            super.new(name, parent); \
        endfunction : new
`endif

`ifndef uvm_component_create
    `define uvm_component_create(_type_name_, _inst_name_, _id_ = 0) \
        _inst_name_ = _type_name_::type_id::create($sformatf({`"_inst_name_`", "_%0d"}, _id_), this);
`endif

`ifndef uvm_reg_new
    `define uvm_reg_new(_size_) \
        function new (string name = ""); \
            super.new(name, _size_, UVM_NO_COVERAGE); \
        endfunction
`endif

`ifndef uvm_reg_create
    `define uvm_reg_create(_reg_type_, _inst_name_) \
        _inst_name_ = _reg_type_::type_id::create(`"_inst_name_`", null, get_full_name()); \
        _inst_name_.configure(this); \
        _inst_name_.build();
`endif

`ifndef uvm_reg_field_create
    `define uvm_reg_field_create(_inst_name_) \
        _inst_name_ = uvm_reg_field::type_id::create(`"_inst_name_`", , get_full_name());
`endif

`ifndef dsp_dump_to_file
    `define dsp_dump_to_file(_nofbytes_, _name_, _v_, _d_, _clk_, _folder_ = "", _id_ = 0, _use_id_ = 0) \
    file_io #(_nofbytes_) file_``_name_; \
    initial begin \
        if (_use_id_ == 1) \
            file_``_name_ = new({_folder_, $sformatf({`"_name_`", "_%0d"}, _id_), ".bin"}, "wb"); \
        else \
            file_``_name_ = new({_folder_, `"_name_`", ".bin"}, "wb"); \
    end \
    always @(posedge _clk_) \
    begin : _name_ \
        if (_v_ == 1) begin \
            file_``_name_.write(_d_); \
        end \
    end
`endif

typedef enum bit { RX_MODE = 0, TX_MODE = 1 } t_driver_mode;