/**
 * @author Mario Kuka <kuka@cesnet.cz>
 */

#ifndef _P4_INT_EXPORTER_H_
#define _P4_INT_EXPORTER_H_

#include "p4int.h"
#include "ringbuffer.h"

#define RING_BUFFER_SIZE 1000000

/**
 * Sending int reports to the influxdb by udp or http protocol.
 * Multithreading is supported, each buffer is processed by a separate thread.
 */
class IntExporter
{
    public:
        /**
         * Constructor
         * \param opt Program options
         */
        IntExporter(const options_t *opt);

        /**
         * Send int report,
         * \param telemetric
         * \return EXIT_SUCCESS on success and EXIT_FAILURE on error
         */
        bool sendData(const telemetric_hdr_t& telemetric);

    protected:
        // Number of threads
        uint32_t m_th_num;
        // Ring bufferes
        std::vector<ringbuffer<telemetric_hdr_t, RING_BUFFER_SIZE>*> m_ring_buffs;
        // Rouind robin index
        uint32_t m_rr_index;
};

#endif // _P4_INFLUXDB_H_
