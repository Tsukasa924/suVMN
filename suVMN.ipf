#pragma rtGlobals=1		// Use modern global access method and strict wave access.
// Morishita-Narita (MN) method for subtracting a vapor IR spectrum from an sample IR spectrum. 
// suVMN version 1.924 
// last update: 2019/12/1

macro suVMN_1924(datanumber,dataname,startnumber)
string dataname="Absdata" // IR spectra shoud look $(dataname+num2str(i))
variable datanumber=3 // total number of the spectra
variable startnumber=0
variable counter_vap=0

silent 1;pauseupdate;

do
	vap_main(dataname,startnumber,datanumber)
	counter_vap+=1
	startnumber+=1
while(counter_vap!=datanumber)

kenkyushitsu_no_koe()
end
////////////////////////////////////////////////////////////////
function vap_main(dataname,startnumber,datanumber)
string dataname
variable startnumber
variable datanumber
variable Best_Vcoef
string filename=dataname+num2str(startnumber)

// user defined parameters // 
variable suijoukiA=4 //�C�ӂɐݒ�
variable suijoukiB=5 //�C�ӂɐݒ�
variable Vcoef=-10 // minimun of a coefficient (variable) for subtraction // aribitary
variable Max_Vcoef=10 // maximum of a coefficient (variable) for subtraction // arbitary 
variable dc=0.001 // step width (>=0.001)

duplicate/o $("suijouki"+num2str(suijoukiA)) vap //vap�������C�̃X�y�N�g��
duplicate/o $("suijouki"+num2str(suijoukiA)) vapSpectra1
duplicate/o $("suijouki"+num2str(suijoukiB)) vapSpectra2
vap=-log(vapSpectra1/vapSpectra2)

duplicate/o $(filename) originalA, subB

Best_Vcoef=opt(1000, Vcoef, Max_Vcoef+0.01, 1)
Best_Vcoef=opt(1000, Best_Vcoef-0.5, Best_Vcoef+0.5, 0.1)
Best_Vcoef=opt(1000, Best_Vcoef-0.1, Best_Vcoef+0.1, 0.01)
Best_Vcoef=opt(1000, Best_Vcoef-10*dc, Best_Vcoef+10*dc, dc)

print filename+", coefficeint = "+num2str(Best_Vcoef)

subB=originalA-Best_Vcoef*vap
duplicate/o subB $("vap_"+filename)

KillWaves vap, originalA, subB, Ftest1, Ftest1_out, vapSpectra1, vapSpectra2

end
////////////////////////////////////////////////////////////////
function opt(rec, Vcoef, Max_Vcoef, dc)
variable rec
variable Vcoef
variable Max_Vcoef
variable dc
variable B_Vcoef
wave subB
wave originalA
wave vap

do
	subB=originalA-Vcoef*vap
	
	duplicate/o subB Ftest1 //Ftest1�̓t�[���G�ϊ��p��wave
	DeletePoints 0,1, Ftest1 //FFT�ł���悤�Ƀf�[�^���̒����@����wave�̃f�[�^���������Ȃ炱�̍s�͂���Ȃ�
	FFT/OUT=2/RP=[2075,3112]/DEST=Ftest1_out Ftest1 //�t�[���G�ϊ����s []���͕���\2cm-1�A����͈�400~4000cm-1�̂Ƃ��̒l
	
	wavestats/q/r=[51,519] Ftest1_out //�t�[���G�ϊ���̍����g�̈�(�����C���̗̈�)�ɂ��āA���̕��ϒl�ɑ΂���W���΍����Ƃ��Ă���
	
	if(rec>v_sdev) //����܂ł̕W���΍��̒��ōł��l�������������炻�̂Ƃ��̌W�����x�X�g�Ƃ݂Ȃ�
		rec=v_sdev
		B_Vcoef=Vcoef
	else
	endif

	Vcoef+=dc
while(Vcoef<Max_Vcoef)

return B_Vcoef
end