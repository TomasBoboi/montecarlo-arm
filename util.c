#include <stdint.h>

typedef unsigned int size_t;

typedef struct 
{
	uint32_t DR;
 	uint32_t RSR_ECR;
 	uint8_t reserved1[0x10];
 	const uint32_t FR;
 	uint8_t reserved2[0x4];
 	uint32_t LPR;
 	uint32_t IBRD;
 	uint32_t FBRD;
 	uint32_t LCR_H;
 	uint32_t CR;
 	uint32_t IFLS;
 	uint32_t IMSC;
 	const uint32_t RIS;
 	const uint32_t MIS;
 	uint32_t ICR;
 	uint32_t DMACR;
}uart_t;

volatile uart_t * const UART0 = (uart_t *) 0x101f1000;

extern void write_str(const char *s);
extern void write_byte(const uint8_t v);
extern void write_word(const uint32_t v);
extern void *memcpy(void *dest, const void *src, size_t len);
extern void *memmove (void *dest, void *src, size_t len);
extern int memcmp (const void *str1, const void *str2, size_t count);
void *memset (void *dest, int val, size_t len);

void write_byte(const uint8_t v)
{
	uint8_t val = v;
	char str[4]={0,0,0,0};
	uint8_t no_digits=0;
	uint8_t i=0;
	if (val == 0)
	{
		UART0->DR = (unsigned int)('0'); 	
	}
	else 
	{
		while (val)
		{
			str[no_digits] = val % 10;
			val = val / 10;
			no_digits++;
		}

		for (i=0;i<no_digits;i++)
		{
			UART0->DR = (unsigned int)(str[no_digits-1-i]+'0'); 
		}
	}

}

void write_word(const uint32_t v)
{
	uint32_t val = v;
	char str[16];
	uint8_t no_digits = 0;
	uint8_t i=0;
	if (val == 0)
	{
		UART0->DR = (unsigned int)('0'); 	
	}
	else
	{
		while (val)
		{
			str[no_digits] = val % 10;
			val = val / 10;
			no_digits++;
			if(val == 3)
				str[no_digits++] = '.' - 48;
		}

		for (i=0;i<no_digits;i++)
		{
			UART0->DR = (unsigned int)(str[no_digits-1-i]+'0'); 
		}
		if(no_digits < 6)
		{
			UART0->DR = (unsigned int)('\t');
			UART0->DR = (unsigned int)('\t');
		}
		else
			UART0->DR = (unsigned int)('\t');
	}
}



void write_str(const char *s) 
{
	while(*s != '\0') 
	{ /* Loop until end of string */
 		UART0->DR = (unsigned int)(*s); /* Transmit char */
 		s++; /* Next char */
 	}
}


void *memcpy (void *dest, const void *src, size_t len)
{
  char *d = dest;
  const char *s = src;
  while (len--)
    *d++ = *s++;
  return dest;
}


void *memmove (void *dest, void *src, size_t len)
{
  char *d = dest;
  char *s = src;
  if (d < s)
    while (len--)
      *d++ = *s++;
  else
    {
      char *lasts = s + (len-1);
      char *lastd = d + (len-1);
      while (len--)
        *lastd-- = *lasts--;
    }
  return dest;
}

int memcmp (const void *str1, const void *str2, size_t count)
{
  const unsigned char *s1 = str1;
  const unsigned char *s2 = str2;

  while (count-- > 0)
    {
      if (*s1++ != *s2++)
	  return s1[-1] < s2[-1] ? -1 : 1;
    }
  return 0;
}

void *memset (void *dest, int val, size_t len)
{
  unsigned char *ptr = dest;
  while (len-- > 0)
    *ptr++ = val;
  return dest;
}