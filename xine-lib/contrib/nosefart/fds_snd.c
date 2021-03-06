/*
** Nofrendo (c) 1998-2000 Matthew Conte (matt@conte.com)
**
**
** This program is free software; you can redistribute it and/or
** modify it under the terms of version 2 of the GNU Library General 
** Public License as published by the Free Software Foundation.
**
** This program is distributed in the hope that it will be useful, 
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
** Library General Public License for more details.  To obtain a 
** copy of the GNU Library General Public License, write to the Free 
** Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston,
** MA 02110-1301, USA.
**
** Any permitted reproduction of these routines, in whole or in part,
** must bear this legend.
**
**
** fds_snd.c
**
** Famicom Disk System sound emulation
** $Id: fds_snd.c,v 1.2 2003/12/05 15:55:01 f1rmb Exp $
*/

#include "types.h"
#include "nes_apu.h"
#include "fds_snd.h"

static int32 fds_incsize = 0;

/* mix sound channels together */
static int32 fds_process(void)
{
   int32 output;
   output = 0;

   return output;
}

/* write to registers */
static void fds_write(uint32 address, uint8 value)
{
}

/* reset state of vrcvi sound channels */
static void fds_reset(void)
{
   fds_incsize = apu_getcyclerate();
}

static void fds_init(void)
{
}

/* TODO: bleh */
static void fds_shutdown(void)
{
}

static apu_memwrite fds_memwrite[] =
{
   { 0x4040, 0x4092, fds_write }, 
   {     -1,     -1, NULL }
};

apuext_t fds_ext = 
{
   fds_init,
   fds_shutdown,
   fds_reset,
   fds_process,
   NULL, /* no reads */
   fds_memwrite
};

/*
** $Log: fds_snd.c,v $
** Revision 1.2  2003/12/05 15:55:01  f1rmb
** cleanup phase II. use xprintf when it's relevant, use xine_xmalloc when it's relevant too. Small other little fix (can't remember). Change few internal function prototype because it xine_t pointer need to be used if some xine's internal sections. NOTE: libdvd{nav,read} is still too noisy, i will take a look to made it quit, without invasive changes. To be continued...
**
** Revision 1.1  2003/01/08 07:04:35  tmmm
** initial import of Nosefart sources
**
** Revision 1.3  2000/07/03 02:18:53  matt
** much better external module exporting
**
** Revision 1.2  2000/06/20 04:06:16  matt
** migrated external sound definition to apu module
**
** Revision 1.1  2000/06/20 00:06:47  matt
** initial revision
**
*/
