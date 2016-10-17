package main;

public class Transition {

	/**
	 * 
	 * @param P	wzorzec
	 * @param A	alfabet
	 * @return	funkcja przejœæ
	 */
	public int[][] computeTransitionFunction(String P, char[] E){
		int m = P.length();
		int k, q;
		int[][] d = new int[m + 1][E.length];
		
		for(q = 0; q <= m; q++){
			for(char e : E){
				k = Math.min(m + 1, q + 2);

				do{
					k--;
				}while(!(P.substring(0, q) + Character.toString(e)).endsWith(P.substring(0, k)));
				
				d[q][e - 97] = k;
			}
		}
		print(d);
		return d;
	}


	private void print(int[][] d) {
		for(int i = 0; i < d.length; i++){
			for(int j = 0; j < d[i].length; j++){
				System.out.print(d[i][j] + " ");
			}
			System.out.println();
		}
		
	}
}
