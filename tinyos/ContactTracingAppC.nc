#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "ContactTracing.h"

configuration ContactTracingAppC
{
}

implementation
{
    components MainC, SerialPrintfC, SerialStartC, ContactTracingC as App;
    components new TimerMilliC() as Timer;

    // Radio components
    components new AMSenderC(6);
    components new AMReceiverC(6);
    components ActiveMessageC;

    App.Boot -> MainC;

    App.Timer -> Timer;

    // Radio wiring
    App.Receive -> AMReceiverC;
    App.AMSend -> AMSenderC;
    App.AMControl -> ActiveMessageC;
    App.Packet -> AMSenderC;
}
