# R code of eco-epidemiological model of tick-borne pathogen (parameters and initial conditions are listed in Table 2 of the main text). 
# requires the package deSolve
require("deSolve")

# define the function
multihostTICK.model <- function( t, x, parameters )
  
{ l <- x[1]
sn <- x[2]
In <- x[3]
sa <- x[4]
ia <- x[5]
sw <- x[6]
iw <- x[7]
rw <- x[8]
sb <- x[9]
ib <- x[10]
rb <- x[11]
nj  <- x[12]
np <- x[13]

with(as.list(parameters),
     { nv <- l+sn+In+sa+ia
     nw <- sw+iw+rw
     nb <- sb+ib+rb
     nj  <- nj
     np <- np
     nd <- 0
     prop_l <- l/(l+In+sn+ia+sa)
     prop_In <- In/(l+In+sn+ia+sa)
     prop_sn <- sn/(l+In+sn+ia+sa)
     prop_sa <- sa/(l+In+sn+ia+sa)
     prop_ia <- ia/(l+In+sn+ia+sa)
     mw <- M[1]
     mb <- M[2]
     mj  <- M[3]
     mp <- M[4]
     r.temp.w<-ifelse(t %% 1 < 2/3, gw[2],gw[1])
     r.temp.b<-ifelse(t %% 1 < 2/3, gb[2],gb[1])
     vj  <- (mj**-0.25)
     vp <- (mp**-0.25)
     rhoj  <- (0.4*(mj**-0.25))
     rhop <- (0.4*(mp**-0.25))
     Kw <- (16.2*(mw**-0.70))
     Kb <- (16.2*(mb**-0.70))
     Kj <- (16.2*(mj**-0.70))
     Kp <- (16.2*(mp**-0.70))
     sigmaw <-  sigma[1]
     sigmab <-  sigma[2]
     cwb<-c.mat[1]
     cwj<-c.mat[7]
     cbw<-c.mat[2]
     cbj<-c.mat[8]
     cjw<-c.mat[10]
     cjb<-c.mat[11]
     deltaw <- delta[1]
     deltab <- delta[2]
     deltaj <- delta[4]
     sv <- (0.5+(0.049*log((1.01+((sa+ia)/2))/(nw+nb+nj+np+nd))))
     
     dl <- (beta[7]*d[1]*nw+beta[7]*d[1]*nb+beta[8]*d[2]*nj+beta[9]*d[3]*np+beta[9]*d[4]*nd)*(sa+ia)*(num_egg-sv*nv)-rhov[2]*l-(beta[1]*nw*l+beta[1]*nb*l+beta[2]*nj*l+beta[3]*np*l+beta[3]*nd*l)*(1+1/k)
     # nymphal stage
     dIn <- (beta[1]*d[1]*iw*tauw[1]*l+beta[1]*d[1]*taub[1]*ib*l)* (1+1/k)-rhov[3]*In-(beta[4]*nw*In+beta[4]*nb*In+beta[5]*nj*In+beta[6]*np*In+beta[6]*nd*In)*(1+1/k)
     dsn <- (beta[1]*d[1]*(rw+sw)*l+beta[1]*d[1]*(rb+sb)*l)+beta[2]*d[2]*nj*l+beta[3]*d[3]*np*l+beta[3]*d[4]*nd*l-rhov[3]*sn-beta[4]*nw*sn-beta[4]*nb*sn-beta[5]*nj*sn-beta[6]*np*sn-beta[6]*nd*sn
     # adult stage
     dia <- beta[4]*d[1]*nw*In+beta[4]*d[1]*nb*In+beta[5]*d[2]*nj*In+beta[6]*d[3]*np*In+beta[6]*d[4]*nd*In+(beta[4]*d[1]*ib*taub[2]*sn+ beta[4]*d[1]*iw*tauw[2]*sn)*(1+1/k)-rhov[4]*ia-(beta[7]*nw*ia+beta[7]*nb*ia+beta[8]*nj*ia+beta[9]*np*ia+beta[9]*nd*ia)*(1+1/k)
     dsa <- (beta[4]*d[1]*(rw+sw)*sn+beta[4]*d[1]*(rb+sb)*sn)+beta[5]*d[2]*nj*sn+beta[6]*d[3]*np*sn+beta[6]*d[4]*nd*sn-rhov[4]*sa-beta[7]*nw*sa-beta[7]*nb*sa-beta[8]*nj*sa-beta[9]*np*sa-beta[9]*nd*sa
     
     # hosts
     dsw <- r.temp.w*nw*((Kw-nw-cwb*nb-cwj*nj)/Kw) -tauv[1]*beta[4]*sw*In-tauv[2]*beta[7]*sw*ia - ((g*sw^2)/(sw^2+h^2)) - ((alfa*np*sw)/(deltaw+nw+((deltaw/deltab)*nb+(deltaw/deltaj)*nj)))
     diw <- tauv[1]*beta[4]*sw*In + tauv[2]*beta[7]*sw*ia -sigmaw*iw -((g*iw^2)/(iw^2+h^2))- ((alfa*np*iw)/(deltaw+nw+((deltaw/deltab)*nb+(deltaw/deltaj)*nj)))
     drw <- sigmaw*iw - ((g*rw^2)/(rw^2+h^2)) - ((alfa*np*rw)/(deltaw+nw+((deltaw/deltab)*nb+(deltaw/deltaj)*nj)))
     dsb <- r.temp.w*nb*((Kb-nb-cbw*nw-cbj*nj)/Kb) -tauv[1]*beta[4]*sb*In-tauv[2]*beta[7]*sb*ia- ((g*sb^2)/(sb^2+h^2)) - ((alfa*np*sb)/(deltab+nb+((deltab/deltaw)*nw+(deltab/deltaj)*nj)))  
     dib <- tauv[1]*beta[4]*sb*In + tauv[2]*beta[7]*sb*ia - sigmab*ib - ((g*ib^2)/(ib^2+h^2))- ((alfa*np*ib)/(deltab+nb+((deltab/deltaw)*nw+(deltab/deltaj)*nj)))
     drb <- sigmab*ib - ((g*rb^2)/(rb^2+h^2)) -((alfa*np*rb)/(deltab+nb+((deltab/deltaw)*nw+(deltab/deltaj)*nj)))
     dnj  <- (vj-rhoj)*nj*((Kj-nj-cjw*nw-cjb*nb)/Kj) - ((g*nj^2)/(nj^2+h^2))-((alfas*np*nj)/(deltaj+nj+((deltaj/deltaw)*nw+(deltaj/deltab)*nb)))
     dnp <- (vp-rhop)*np*(1-((q*np)/(nw+(deltaw/deltab)*nb+(deltaw/deltaj)*nj))) 
     res <- c(dl,dsn,dIn,dsa,dia,dsw,diw,drw,dsb,dib,drb,dnj,dnp) 
     list(res)
     
     }
)}

# parameters
times <- seq(0,20,length=7300)  # 20 years daily time step

N.crit<-11   
d.high<-2.5 

gw<-c(-0.006,0.04)  # wood mouse growth rates
gb<-c(-0.002,0.007)  # bank vole growth rates

M<-c(0.02025503,0.01906557,0.02175, 0.0092,0.07845) # body mass in g for wood mouse, bank vole, common shrew, and weasel respectively

alfa <- 1 # for rodents
alfas<-7.674456522 # for shrews
delta <- c(11.31050155,11.31050155,11.31050155,22.621)   
# shrew value is doubled because not preferred prey

# competition factors vectors
cwb_sens.an <- seq(0, 0.9851319, length.out = 6)
cbw_sens.an <- seq(0, 1.015092, length.out = 6)
cfw_sens.an <- seq(0, 0.9513746,length.out = 6)
cfb_sens.an <- seq(0,0.9119129,length.out = 6)
cwf_sens.an <- seq(0,1.051111,length.out = 6)
cbf_sens.an <- seq(0,1.096596,length.out = 6)
cwj_sens.an <- seq(0, 0.5744988, length.out = 6)
cbj_sens.an <- seq(0, 0.5831694, length.out = 6)
cfj_sens.an <- seq(0,0.5475578,length.out = 6)
cjw_sens.an <- seq(0, 1.740648, length.out = 6)
cjb_sens.an <- seq(0, 1.714768, length.out = 6)
cjf_sens.an <- seq(0, 1.826291,length.out = 6)

# matrix for competition factors to be included in the model
c.mat<-c(cwb_sens.an[2],cbw_sens.an[2],cfw_sens.an[2],cfb_sens.an[2],cwf_sens.an[2],cbf_sens.an[2],cwj_sens.an[2],cbj_sens.an[2],cfj_sens.an[1],cjw_sens.an[4],cjb_sens.an[4],cjf_sens.an[5])

# contact rates
beta <- c(0.040,0.04,0.025,0.04,0.04,0.04,0.02,0.02,0.06)

# molting success
d <- c(0.415,0.496,0.639,0.563)/3  

num_egg = 1500 # for I. ricinus tick per capita birth rate of larval ticks
num_egg = 1000 # for I. scapularis

rhov <- c(0.002,0.001428,0.000476,0.000408) # per capita natural death rate of tick eggs

g= 0 # or 0.49312 # estimated according to the formula proposed by Turchin and Hanski 1997 
h = 9.9 
q= 56 # estimation according to Turchin and Hanski 1997 but with data from UK
sigma <- c(0.0083,0.0083) # recovery rate 
# to be changed for Babesia see Table 2 main text

k = 0.18 # dispersion parameter estimated from empirical data
taur=0.5 # competence of transmission rodent to vector
tauv=0.8 # competence of transmission vector to rodent

# perform a realisation
# change initial conditions (xstart) of populations or parameter value of molting/competence according to scenario wished to be simulated
parameters <- c(M=M, alfa=alfa, alfas=alfas, delta=delta,c.mat=c.mat,g=g, h=h, q=q, sigma=sigma, taur=taur, tauv=tauv, k=k, gw=gw,gb=gb,N.crit=N.crit)
xstart<-c(l=0,In=0,sn=100,ia=0,sa=0,sw=48,iw=1,rw=0,sb=75,ib=0,rb=0, nj=20, np=3)
output<-as.data.frame(rk4(xstart,times,multihostTICK.model,parameters))
