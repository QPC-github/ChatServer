/*
 * jabberd - Jabber Open Source Server
 * Copyright (c) 2002-2003 Jeremie Miller, Thomas Muldowney,
 *                         Ryan Eatmon, Robert Norris
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA02111-1307USA
 */

#include "sm.h"

/** @file sm/dispatch.c
  * @brief packet dispatcher
  * @author Robert Norris
  * $Date: 2006/03/14 23:27:27 $
  * $Revision: 1.1 $
  */

/** main packet dispatcher */
void dispatch(sm_t sm, pkt_t pkt) {
    user_t user;
    mod_ret_t ret;

    /* handle broadcasts */
    if(pkt->rtype == route_BROADCAST) {
        log_debug(ZONE, "can't handle broadcast routes (yet), dropping");
        pkt_free(pkt);
        return;
    }

    /* routing errors, add a im error */
    if(pkt->rtype & route_ERROR)
        pkt_error(pkt, stanza_err_REMOTE_SERVER_NOT_FOUND);

    /*
     * - if its from the router (non-route) it goes straight to pkt_router
     * - hand it to in_router chain
     * - if its for the sm itself (no user), hand it to the pkt_sm chain
     * - find the user
     * - hand to pkt_user
     */

    /* non route packets are special-purpose things from the router */
    if(!(pkt->rtype & route_UNICAST)) {
        ret = mm_pkt_router(pkt->sm->mm, pkt);
        switch(ret) {
            case mod_HANDLED:
                break;

            case mod_PASS:
            default:
                /* don't ever bounce these */
                pkt_free(pkt);

                break;
        }

        return;
    }

    /* preprocessing */
    ret = mm_in_router(pkt->sm->mm, pkt);
    switch(ret) {
        case mod_HANDLED:
            return;

        case mod_PASS:
            break;

        default:
            pkt_router(pkt_error(pkt, -ret));
            return;
    }

    /* has to come from someone */
    if(pkt->from == NULL) {
        pkt_router(pkt_error(pkt, stanza_err_BAD_REQUEST));
        return;
    }

    /* packet is for the sm itself */
    if(pkt->to != NULL && *pkt->to->node == '\0') {
        ret = mm_pkt_sm(pkt->sm->mm, pkt);
        switch(ret) {
            case mod_HANDLED:
                break;

            case mod_PASS:
                ret = -stanza_err_FEATURE_NOT_IMPLEMENTED;

            default:
                pkt_router(pkt_error(pkt, -ret));
    
                break;
        }

        return;
    }

    /* get the user */
    user = user_load(sm, pkt->to);
    if(user == NULL) {
        pkt_router(pkt_error(pkt, stanza_err_ITEM_NOT_FOUND));
        return;
    }
    
    ret = mm_pkt_user(pkt->sm->mm, user, pkt);
    switch(ret) {
        case mod_HANDLED:
            break;
    
        case mod_PASS:
            ret = -stanza_err_FEATURE_NOT_IMPLEMENTED;

        default:
            pkt_router(pkt_error(pkt, -ret));

            break;
    }

    /* if they have no sessions, they were only loaded to do delivery, so free them */
    if(user->sessions == NULL)
        user_free(user);
}