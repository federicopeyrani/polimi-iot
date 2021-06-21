#include "printf.h"
#include "Timer.h"
#include "ContactTracing.h"

module ContactTracingC @safe()
{
    uses {
        interface Boot;
        interface Leds;
        interface Timer<TMilli> as Timer;

        // Radio interfaces
        interface Receive;
        interface AMSend;
        interface SplitControl as AMControl;
        interface Packet;
    }
}

implementation
{

    uint16_t counter = 0;
    message_t packet;

    event void Boot.booted()
    {
        call AMControl.start();
    }

    event void AMControl.startDone(error_t err) {
        if (err != SUCCESS) {
            call AMControl.start();
            return;
        }

        call Timer.startPeriodic(PERIOD);
        printf("Started radio\n");

        printfflush();
    }

    event void AMControl.stopDone(error_t err) {
        // skip
    }

    event void Timer.fired()
    {
        exposure_notification_t* msg = (exposure_notification_t*) call Packet.getPayload(&packet, sizeof(exposure_notification_t));

        if (msg == NULL) {
            return;
        }

        // inflate message payload
        msg->sender_id = TOS_NODE_ID;
        msg->counter = counter;

        // send message
        call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(exposure_notification_t));
    }

    event void AMSend.sendDone(message_t* bufPtr, error_t error) {
        if (&packet == bufPtr) {
            counter++;
        }
    }

    event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
        if (len == sizeof(exposure_notification_t)) {
            exposure_notification_t* msg = (exposure_notification_t*) payload;
            printf("{\"node_id\":%u,\"sender_id\":%u,\"counter\":%u}\n", TOS_NODE_ID, msg->sender_id, msg->counter);
            printfflush();
        }

        return bufPtr;
    }
}
