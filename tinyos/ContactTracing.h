#ifndef BROADCAST_COUNT_H
#define BROADCAST_COUNT_H

#define PERIOD 500

enum {
  AM_MY_MSG = 6,
};

typedef nx_struct exposure_notification{
    nx_uint16_t sender_id;
    nx_uint16_t counter;
}
exposure_notification_t;

#endif
