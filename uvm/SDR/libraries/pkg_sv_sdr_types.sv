//--------------------------------------------------------------------------------------------------------------------------------
// name : pkg_sv_sdr_types
//--------------------------------------------------------------------------------------------------------------------------------
package pkg_sv_sdr_types;
    typedef struct{
        int i;
        int q;
    } t_iq;

    typedef int t_int_array[];
    typedef int t_int_queue[$];
    typedef real t_real_array[];
    typedef int t_int_array_of_queue[][$];

    typedef struct{
        t_int_array i;
        t_int_array q;
    } t_iq_int_array;
    typedef struct{
        t_real_array i;
        t_real_array q;
    } t_iq_real_array;
    typedef struct {
        t_int_queue i;
        t_int_queue q;
    } t_iq_int_queue_array;
//-------------------------------------------------------------------------------------------------------------------------------
endpackage