#include <iostream>
#include <math.h>
#include<cstdio>
#include<list>

using namespace std;

class Cache_content{
	public:
	    int age;  //set,block LRU
	    int *blockage;
        bool v;
        unsigned int  *tag;
        Cache_content(){;}
        Cache_content(int associative)
        {
            tag = new unsigned int[associative]();
            blockage = new int[associative]();
            v = false;
            age = 0;
        }
        ~Cache_content()
        {
            delete [] tag;
            delete [] blockage;
        }

};

const int K = 1024;

void simulate(int cache_size, int block_size,int asso){
    int instruction = 0;
    list<int> hit,miss;
	unsigned int tag,index,x;
    int asso_bit = log2(asso);
	int offset_bit = (int) log2(block_size);
	int index_bit = (int) log2(cache_size/block_size/asso);
	int line= cache_size>>(offset_bit);
    line = line >> asso_bit;
    Cache_content **cache;
    cache = new Cache_content *[line];
    for(int i = 0;i < line;i++)
    {
        cache[i] = new Cache_content(asso);
    }


  FILE * fp=fopen("Trace.txt","r");					//read file

	while(fscanf(fp,"%x",&x)!=EOF){
        instruction++;
        //cout<<hex<<x<<" " <<endl;
		index=(x>>offset_bit)&(line-1);
		tag=x>>(index_bit+offset_bit);
		cache[index]->age++;  //older
		bool found = false;  //if find in the set
		if(cache[index]->v)
        {
            for(int i = 0;i <= asso_bit;i++)
            {
                if(cache[index]->tag[i] == tag && !found)
                {
                    hit.push_back(instruction);
                    cache[index]->blockage[i] = cache[index]->age;
                    found = true;
                }
            }
            if(!found)
            {
                miss.push_back(instruction);
                int youngest = cache[index]->blockage[0],position = 0;
                for(int i = 1;i <= asso_bit;i++)      //find LRU
                {
                    if(cache[index]->blockage[i] < youngest)
                    {
                        youngest = cache[index]->blockage[i];
                        position = i;
                    }
                }
                cache[index]->tag[position] = tag;
                cache[index]->blockage[position] = cache[index]->age;
            }
        }
        else
        {
            miss.push_back(instruction);
            cache[index]->v=true;
            cache[index]->tag[0] = tag;
            cache[index]->blockage[0] = cache[index]->age;
        }
		/*if(cache[index].v && cache[index].tag==tag){
			cache[index].v=true; 2			//hit
		}
		else{
			cache[index].v=true;			//miss
			cache[index].tag=tag;
		}*/
	}
	fclose(fp);
	double size = miss.size()*100,count = instruction;
	double missrate = size/count;
	cout << "Hits instructions: ";
	list<int>::iterator it;
	list<int>::iterator end = hit.end();
	--end;
	for(it = hit.begin();it != end;it++)
    {
        cout << *it << ",";
    }
    it = end;
    cout << *it << endl;
    cout << "Misses instructions: ";
    end = miss.end();
    end--;
    for(it = miss.begin();it != end;it++)
    {
        cout << *it << ",";
    }
    it = end;
    cout << *it << endl;
    cout << "Miss rate: "<<missrate << "%"<<endl;
    for(int i = 0;i < line;i++)
    {
        delete  cache[i];
    }
    delete [] cache;
}

int main(){
	// Let us simulate 4KB cache with 16B blocks
    //simulate(64, 0,1);
    simulate(32*K, 32,1);
    simulate(32*K, 32,2);
    simulate(32*K, 32,4);
    simulate(32*K, 32,8);
    /*for(int k = 6;k <= 9;k++)
    {
        int i = pow(2,k);
        simulate(1*i, 4,1);
        simulate(1*i, 8,1);
        simulate(1*i, 16,1);
        simulate(1*i, 32,1);
        cout << endl;
    }*/
}
