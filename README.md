SoC (System On Chip)
====================

La idea
-------

La idea es muy preliminar. Esta basado en la cpu J1 de James Bowman, pero con
algunas modificaciones.


Objetivo
--------

Sistema basado varias CPU's con una region de memoria compartida.
Estas CPU estan basadas en el modelo J1, reescrito desde cero, pero al
que se llega a la misma conclusion ya que el modelo es casi perfecto!!!.
Las mayores modificaciones son reescritura en modulos, variaciones en la 
ALU y en el codigo de las instrucciones.

Unidad de control ciclico para el acceso al area comun de memoria. Esta
memoria es la que permite la comunicacion entre CPU's. Si se produce algun
acceso al area compartida, el reloj de la CPU se detiene hasta que quede
libre. 
    
Canal de comunicaciones serie, con el exterior
   
Obiamente programable en FORTH
    
Implementado en una placa D0-Nano con Quartus-II v14.1.
    
Simulacion con Verilator/GTWave
    
No hay prisa. Es un proyecto meramente hobby/academico
